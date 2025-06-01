# Install openai module 
# pip3 install openai
# sudo apt install jq -y

from openai import OpenAI
import sys

client = OpenAI()

def analyze(log_content):
    prompt = f"""You're a CI/CD assistant helping developers. Please do the following:

1. Clearly **summarize the root cause of the Jenkins build failure**.
2. Provide a **separate section** with a **suggested fix**, formatted as:

**🧠 AI Analysis:**
<analysis here>

**🔧 Suggested Fix:**
<fix instructions here>

Keep the output developer-friendly and readable.

Here is the Jenkins log:
{log_content}

Respond only with the formatted output.
"""
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.2,
        max_tokens=400
    )
    return response.choices[0].message.content.strip()

if __name__ == "__main__":
    with open(sys.argv[1], 'r') as f:
        log = f.read()
    print(analyze(log))
