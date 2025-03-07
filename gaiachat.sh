#!/bin/bash

# Function to check if NVIDIA CUDA or GPU is present
check_cuda() {
    if command -v nvcc &> /dev/null || command -v nvidia-smi &> /dev/null; then
        echo "✅ NVIDIA GPU with CUDA detected."
        return 0  # CUDA is present
    else
        echo "❌ NVIDIA GPU Not Found."
        return 1  # CUDA is not present
    fi
}

# Function to check if the system is a VPS, Laptop, or Desktop
check_system_type() {
    vps_type=$(systemd-detect-virt)
    if echo "$vps_type" | grep -qiE "kvm|qemu|vmware|xen|lxc"; then
        echo "✅ This is a VPS."
        return 0  # VPS
    elif ls /sys/class/power_supply/ | grep -q "^BAT[0-9]"; then
        echo "✅ This is a Laptop."
        return 1  # Laptop
    else
        echo "✅ This is a Desktop."
        return 2  # Desktop
    fi
}

# Function to set the API URL based on system type and CUDA presence
set_api_url() {
    check_system_type
    system_type=$?

    check_cuda
    cuda_present=$?

    if [ "$system_type" -eq 0 ]; then
        # VPS
        API_URL="https://gaias.gaia.domains/v1/chat/completions"
        API_NAME="Hyper"
    elif [ "$system_type" -eq 1 ]; then
        # Laptop
        if [ "$cuda_present" -eq 0 ]; then
            API_URL="https://gaias.gaia.domains/v1/chat/completions"
            API_NAME="Soneium"
        else
            API_URL="https://gaias.gaia.domains/v1/chat/completions"
            API_NAME="Hyper"
        fi
    elif [ "$system_type" -eq 2 ]; then
        # Desktop
        if [ "$cuda_present" -eq 0 ]; then
            API_URL="https://gaias.gaia.domains/v1/chat/completions"
            API_NAME="Gadao"
        else
            API_URL="https://gaias.gaia.domains/v1/chat/completions"
            API_NAME="Hyper"
        fi
    fi

    echo "🔗 Using API: ($API_NAME)"
}

# Set the API URL based on system type and CUDA presence
set_api_url

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

# Function to get a random general question based on the API URL
generate_random_general_question() {
    if [[ "$API_URL" == "https://gaias.gaia.domains/v1/chat/completions" ]]; then
general_questions=(
    "Why is the Renaissance considered a turning point in history?"
    "How did the Industrial Revolution change the world?"
    "Why is the Great Wall of China historically significant?"
    "What were the main causes of World War I?"
    "How did the printing press impact society?"
    "Why is the moon landing in 1969 considered a major achievement?"
    "What led to the fall of the Roman Empire?"
    "How did the Cold War shape global politics?"
    "Why is the Amazon rainforest important for the planet?"
            "What sound does a cat make?"
            "Which number comes after 4?"
            "What is the opposite of 'hot'?"
            "What do you use to brush your teeth?"
            "What is the first letter of the alphabet?"
            "What shape is a football?"
            "How many fingers do humans have?"
    "How do vaccines work to protect against diseases?"
    "What are black holes, and why are they important in astronomy?"
    "How does climate change affect ecosystems?"
    "Why is the discovery of DNA considered revolutionary?"
    "How did the internet change modern communication?"
    "What role does the United Nations play in global peacekeeping?"
    "Why is the Suez Canal important for global trade?"
    "How did the Magna Carta influence modern democracy?"
    "Why is the water cycle crucial for life on Earth?"
    "What are the main challenges of space exploration?"
    "How did the discovery of electricity transform society?"
    "Why is the number zero important in mathematics?"
    "How is the Fibonacci sequence observed in nature?"
    "Why is the Pythagorean theorem significant in geometry?"
    "How does probability influence real-life decision-making?"
    "What are prime numbers, and why are they important in cryptography?"
    "Why is calculus essential in modern science and engineering?"
    "How does the concept of infinity affect mathematical theories?"
    "What is the significance of Euler’s formula in mathematics?"
    "Why is Pi considered an irrational number, and why is it useful?"
    "How does statistics help in making informed decisions?"
)

    elif [[ "$API_URL" == "https://gaias.gaia.domains/v1/chat/completions" ]]; then
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
    elif [[ "$API_URL" == "https://gaias.gaia.domains/v1/chat/completions" ]]; then
        general_questions=(
            "Who is the current President of the United States?"
            "What is the capital of Japan?"
            "Which planet is known as the Red Planet?"
            "Who wrote 'To Kill a Mockingbird'?"
            "What is the largest ocean on Earth?"
            "Which country has the most population?"
            "What is the fastest land animal?"
            "Who discovered gravity?"
            "What color is the sky?"
            "How many legs does a dog have?"
            "What sound does a cat make?"
            "Which number comes after 4?"
            "What is the opposite of 'hot'?"
            "What do you use to brush your teeth?"
            "What is the first letter of the alphabet?"
            "What shape is a football?"
            "How many fingers do humans have?"
            "What is 1 + 1?"
            "What do you wear on your feet?"
            "What animal says 'moo'?"
            "How many eyes does a person have?"
            "What do you call a baby dog?"
            "Which fruit is yellow and curved?"
            "What do you drink when you're thirsty?"
            "What do bees make?"
            "What is the name of our planet?"
            "What do you do with a book?"
            "What color is grass?"
            "What is the opposite of 'up'?"
            "How many wheels does a bicycle have?"
            "Where do fish live?"
            "What do you use to write on a blackboard?"
            "What shape is a pizza?"
            "What do you call a baby cat?"
            "What is 5 minus 2?"
            "What do you use to cut paper?"
            "What is the color of a banana?"
            "What do birds use to fly?"
            "What do you wear on your head to keep warm?"
            "How many days are in a week?"
            "What do you use an umbrella for?"
            "What does ice turn into when it melts?"
            "How many ears does a rabbit have?"
            "Which season comes after summer?"
            "What color is the sun?"
            "What do cows give us to drink?"
            "Which fruit is red and has seeds inside?"
            "What do you do with a bed?"
            "What sound does a duck make?"
            "How many toes do you have?"
            "What do you call a baby chicken?"
            "What do you put on your cereal?"
            "Which is bigger, an elephant or a mouse?"
            "What do you do with a spoon?"
            "How many arms does an octopus have?"
            "What is the color of a strawberry?"
            "Which day comes after Monday?"
            "What do you use to open a door?"
            "What sound does a cow make?"
            "Where do penguins live?"
            "What do you call a baby horse?"
            "What do you use to write on paper?"
            "Which is faster, a car or a bicycle?"
            "How many ears does a human have?"
            "What do you wear on your hands when it’s cold?"
            "What do you use to see things?"
            "What do you do with a pillow?"
            "How many arms does a starfish have?"
            "What is the color of a lemon?"
            "What do you call a house for birds?"
            "Where do chickens live?"
            "Which is taller, a giraffe or a cat?"
            "What do you use to comb your hair?"
            "What do you call a baby sheep?"
            "How many hands does a clock have?"
            "What do you call a place with lots of books?"
            "Which animal has a long trunk?"
            "What is the color of a watermelon?"
            "What do you do with a TV?"
            "What is the opposite of small?"
            "How many sides does a triangle have?"
            "What do you call a group of stars in the sky?"
            "What do you use to eat soup?"
            "What do you use to clean your hands?"
            "What do monkeys love to eat?"
            "Where do polar bears live?"
            "What do you call a baby cow?"
            "What does a clock show?"
            "What do you wear when it’s raining?"
            "What is something that barks?"
            "What do you use to make a phone call?"
            "What do you use to wash your hair?"
            "What do you do with a blanket?"
            "Which animal can hop and has a pouch?"
            "What do you call a baby duck?"
            "What do you use to tie your shoes?"
            "How many wings does a butterfly have?"
            "What do you wear to protect your eyes from the sun?"
            "What do you do with a birthday cake?"
            "What do you wear on your wrist to tell time?"
            "What do you call a baby frog?"
            "What do you eat for breakfast?"
            "What do you do when you’re sleepy?"
            "What is the color of the moon?"
            "How many legs does a spider have?"
            "Where do turtles live?"
            "What do you do with a soccer ball?"
            "What do you call a baby fish?"
            "What do you wear on your head when riding a bike?"
            "What do you do when you hear music?"
        )
    fi

    echo "${general_questions[$RANDOM % ${#general_questions[@]}]}"
}

# Function to handle the API request
send_request() {
    local message="$1"
    local api_key="$2"

    echo "📬 Sending Question to $API_NAME: $message"

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
        echo "⚠️ [ERROR] API request failed | Status: $http_status | Retrying."
        sleep 5
    fi

    # Set sleep time based on API URL
    if [[ "$API_URL" == "https://gaias.gaia.domains/v1/chat/completions" ]]; then
        echo "⏳ Fetching (hyper API)..."
        sleep 1
    elif [[ "$API_URL" == "https://gaias.gaia.domains/v1/chat/completions" ]]; then
        echo "⏳ Fetching (soneium API)..."
        sleep 2
    elif [[ "$API_URL" == "https://gaias.gaia.domains/v1/chat/completions" ]]; then
        echo "⏳ Fetching..."
        sleep 1
    fi
}

API_KEY_DIR="$HOME/gaianet"
mkdir -p "$API_KEY_DIR"

API_KEY_LIST=($(ls "$API_KEY_DIR" 2>/dev/null | grep '^apikey_'))

load_existing_key() {
    if [ ${#API_KEY_LIST[@]} -eq 0 ]; then
        echo "❌ No existing API keys found."
        return
    fi

    echo "🔍 Detected existing API keys:"
    for i in "${!API_KEY_LIST[@]}"; do
        echo "$((i+1))) ${API_KEY_LIST[$i]}"
    done

    echo -n "👉 Select a key to load (Enter number): "
    read -r key_choice

    if [[ "$key_choice" =~ ^[0-9]+$ ]] && ((key_choice > 0 && key_choice <= ${#API_KEY_LIST[@]})); then
        selected_file="${API_KEY_LIST[$((key_choice-1))]}"
        api_key=$(cat "$API_KEY_DIR/$selected_file")
        echo "✅ Loaded API key from $selected_file"
    else
        echo "❌ Invalid selection. Exiting..."
        exit 1
    fi
}

save_new_key() {
    echo -n "Enter your API Key: "
    read -r api_key

    if [ -z "$api_key" ]; then
        echo "❌ Error: API Key is required!"
        exit 1
    fi

    while true; do
        echo -n "Enter a name to save this key (no spaces): "
        read -r key_name
        key_name=$(echo "$key_name" | tr -d ' ')  # Remove spaces

        if [ -z "$key_name" ]; then
            echo "❌ Error: Name cannot be empty!"
        elif [ -f "$API_KEY_DIR/apikey_$key_name" ]; then
            echo "⚠️  A key with this name already exists! Choose a different name."
        else
            echo "$api_key" > "$API_KEY_DIR/apikey_$key_name"
            chmod 600 "$API_KEY_DIR/apikey_$key_name"  # Secure the key file
            echo "✅ API Key saved as 'apikey_$key_name'"
            break
        fi
    done
}

# Main Logic
if [ ${#API_KEY_LIST[@]} -gt 0 ]; then
    echo "📂 Existing API keys detected."
    echo "1) Load an existing API key"
    echo "2) Enter a new API key"
    echo -n "👉 Choose an option (1 or 2): "
    read -r choice

    case "$choice" in
        1) load_existing_key ;;
        2) save_new_key ;;
        *) echo "❌ Invalid choice. Exiting..." && exit 1 ;;
    esac
else
    echo "🔑 No saved API keys found. Please enter a new one."
    save_new_key
fi

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
        sleep 100000
        exit 0
    fi

    random_message=$(generate_random_general_question)
    send_request "$random_message" "$api_key"
done
