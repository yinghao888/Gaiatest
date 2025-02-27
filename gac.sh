#!/bin/bash

# Function to check if NVIDIA CUDA or GPU is present
check_cuda() {
    if command -v nvcc &> /dev/null || command -v nvidia-smi &> /dev/null; then
        echo "✅ NVIDIA GPU with CUDA detected. Proceeding with execution..."
    else
        echo "❌ NVIDIA GPU Not Found. This Bot is Only for GPU Users."
        echo "Press Enter to go back and Run on GPU Device..."  
        read -r  # Waits for user input

        # Restart installer
        rm -rf ~/gaiainstaller.sh
        curl -O https://raw.githubusercontent.com/yinghao888/Gaianet_installer/main/gaiainstaller.sh && chmod +x gaiainstaller.sh && ./gaiainstaller.sh

        exit 1
    fi
}

# Run the check
check_cuda

# Check if jq is installed, and if not, install it
if ! command -v jq &> /dev/null; then
    echo "❌ jq not found. Installing jq..."
    sudo apt update && sudo apt install jq -y
    if [ $? -eq 0 ]; then
        echo "✅ jq installed successfully!"
    else
        echo "❌ Failed to install jq. Please install jq manually and re-run the script."
        exit 1
    fi
else
    echo "✅ jq is already installed."
fi

# List of general questions
general_questions=(
    "What are black holes, and how do they form?"
    "Explain the causes and effects of global warming."
    "What were the main causes of World War II?"
    "How does the human brain process information and memory?"
    "What is artificial intelligence, and how is it impacting modern society?"
    "Explain the process of photosynthesis and its importance in the ecosystem."
    "How does the stock market work, and what factors influence stock prices?"
    "What is quantum computing, and how is it different from classical computing?"
    "Explain the theory of evolution and its significance in biology."
    "What are the major types of renewable energy sources, and how do they work?"
    "How does the immune system fight against diseases?"
    "What is the Big Bang Theory, and what evidence supports it?"
    "How do governments manage a country’s economy, and what are fiscal and monetary policies?"
    "What are the main principles of democracy, and why is it important?"
    "How do airplanes fly? Explain the principles of aerodynamics."
    "What are the different layers of the Earth's atmosphere, and what are their characteristics?"
    "How do volcanoes erupt, and what are the different types of volcanic eruptions?"
    "What is the significance of the Industrial Revolution, and how did it change the world?"
    "How does the human digestive system work, and what are its main organs?"
    "What are the different types of economies (capitalism, socialism, communism), and how do they function?"
    "Explain the process of DNA replication and why it is important for living organisms."
    "What are the major causes and consequences of deforestation?"
    "How does climate change affect biodiversity and ecosystems?"
    "What is the significance of space exploration, and what are some major space missions in history?"
    "How does the internet work, and what are the key technologies behind it?"
    "What are the effects of globalization on economies and cultures?"
    "What is cybersecurity, and why is it important in today’s digital world?"
    "How do electric cars work, and what are their benefits compared to traditional cars?"
    "What are the causes and impacts of ocean pollution?"
    "How does the human heart function, and what are its key components?"
    "What is nanotechnology, and what are its applications in medicine and engineering?"
    "How do vaccines work, and why are they important for public health?"
    "What are the differences between renewable and non-renewable resources?"
    "How do earthquakes occur, and what are the different types of seismic waves?"
    "What are genetic modifications, and how do they impact agriculture and medicine?"
    "Explain the process of the water cycle and its importance in nature."
    "What are some of the biggest technological advancements of the 21st century?"
    "How do wireless communication technologies like 5G work?"
    "What are the key differences between different world religions?"
    "What are the main functions of the United Nations, and why was it formed?"
    "What is cryptocurrency, and how does blockchain technology work?"
    "How does artificial intelligence contribute to advancements in healthcare?"
    "What are some of the most significant scientific discoveries of the last decade?"
    "What is dark matter, and why is it important in astrophysics?"
    "How do different types of governments (democracy, monarchy, dictatorship) operate?"
    "What is the role of media in shaping public opinion and politics?"
    "How do climate change agreements like the Paris Agreement help the environment?"
    "What are the main principles of Einstein’s Theory of Relativity?"
    "How do space telescopes like Hubble and James Webb help us explore the universe?"
    "What is the history and significance of the Great Wall of China?"
    "How does artificial intelligence impact the job market and employment trends?"
    "What are the causes and effects of the Industrial and French Revolutions?"
    "How do submarines work, and what are their uses in military and research?"
    "What is the process of making and storing nuclear energy?"
    "How does the process of genetic engineering work in medicine and agriculture?"
    "What is the role of mitochondria in a cell, and why is it called the powerhouse?"
    "How do climate patterns like El Niño and La Niña impact global weather?"
    "What are the main challenges facing the world’s freshwater supply?"
    "What is cybercrime, and what measures are taken to prevent it?"
    "How does space travel affect the human body?"
    "What are the key differences between socialism and communism?"
    "How do forensic scientists solve crimes using DNA analysis?"
    "What are the biggest challenges in developing a sustainable future?"
    "How do black holes bend space and time, according to general relativity?"
    "What are the major ethical concerns surrounding artificial intelligence?"
    "How does deforestation contribute to climate change?"
    "What are the effects of pollution on marine life?"
    "How do wind turbines generate electricity?"
    "What are the main goals of the European Union, and how does it function?"
    "What is the importance of the ozone layer, and how can we protect it?"
    "How do satellites help in weather forecasting?"
    "What are the dangers of antibiotic resistance, and how can it be prevented?"
    "How does the human body fight against infections and diseases?"
    "What are the major theories about the origin of life on Earth?"
    "How does artificial intelligence work in self-driving cars?"
    "What is the role of big data in business and decision-making?"
    "How do solar panels work, and what are their benefits?"
    "What is the Fibonacci sequence, and where is it found in nature?"
    "How do different cultures influence global cuisine and fashion trends?"
    "What are the psychological effects of social media on human behavior?"
    "How do electric generators convert mechanical energy into electrical energy?"
    "What are the effects of war on a country’s economy and society?"
    "How do historians study ancient civilizations and their cultures?"
    "What is the process of desalination, and how can it solve water scarcity issues?"
    "What are the main challenges of interstellar travel?"
    "How do companies use artificial intelligence for customer service?"
    "What are the ethical concerns related to genetic cloning?"
    "How do environmental policies impact business and industries?"
    "What is the role of women in history, and how has it evolved over time?"
    )

# Function to get a random general question
generate_random_general_question() {
    echo "${general_questions[$RANDOM % ${#general_questions[@]}]}"
}

# Function to handle the API request
send_request() {
    local message="$1"
    local api_key="$2"

    echo "📬 Sending Question: $message"

    json_data=$(cat <<EOF
{
    "messages": [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": "$message"}
    ]
}
EOF
    )

    response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
        -H "Authorization: Bearer $api_key" \
        -H "Accept: application/json" \
        -H "Content-Type: application/json" \
        -d "$json_data")

    http_status=$(echo "$response" | tail -n 1)
    body=$(echo "$response" | head -n -1)

    # Extract the 'content' from the JSON response using jq (Suppress errors)
    response_message=$(echo "$body" | jq -r '.choices[0].message.content' 2>/dev/null)

    if [[ "$http_status" -eq 200 ]]; then
        if [[ -z "$response_message" ]]; then
            echo "⚠️ Response content is empty!"
        else
            ((success_count++))  # Increment success count
            echo "✅ [SUCCESS] Response $success_count Received!"
            echo "📝 Question: $message"
            echo "💬 Response: $response_message"
        fi
    else
        echo "⚠️ [ERROR] API request failed | Status: $http_status | Retrying..."
        sleep 2
    fi
}

# Asking for API Key (loops until a valid key is provided)
while true; do
    echo -n "Enter your API Key: "
    read -r api_key

    if [ -z "$api_key" ]; then
        echo "❌ Error: API Key is required!"
        echo "🔄 Restarting the installer..."

        # Restart installer
        rm -rf ~/gaiainstaller.sh
        curl -O https://raw.githubusercontent.com/yinghao888/Gaiatest/main/gaiainstaller.sh && chmod +x gaiainstaller.sh && ./gaiainstaller.sh 

        exit 1
    else
        break  # Exit loop if API key is provided
    fi
done

# Asking for duration
echo -n "⏳ How many hours do you want the bot to run? "
read -r bot_hours

# Convert hours to seconds
if [[ "$bot_hours" =~ ^[0-9]+$ ]]; then
    max_duration=$((bot_hours * 3600))
    echo "🕒 The bot will run for $bot_hours hour(s) ($max_duration seconds)."
else
    echo "⚠️ Invalid input! Please enter a number."
    exit 1
fi

# Hidden API URL (moved to the bottom)
API_URL="https://gaias.gaia.domains/v1/chat/completions"

# Display thread information
echo "✅ Using 1 thread..."
echo "⏳ Waiting 30 seconds before sending the first request..."
sleep 5

echo "🚀 Starting requests..."
start_time=$(date +%s)
success_count=0  # Initialize success counter

while true; do
    current_time=$(date +%s)
    elapsed=$((current_time - start_time))

    if [[ "$elapsed" -ge "$max_duration" ]]; then
        echo "🛑 Time limit reached ($bot_hours hours). Exiting..."
        echo "📊 Total successful responses: $success_count"
        exit 0
    fi

    random_message=$(generate_random_general_question)
    send_request "$random_message" "$api_key"
    sleep 0
done
