# 🧠 OpenAI Build Failure Analysis for Jenkins

An AI-powered solution for automated Jenkins build log analysis using OpenAI.  
When a build fails, this integration:

✅ Summarizes the root cause  
✅ Suggests a fix  
✅ Formats output for readability  
✅ Sends it via email for developer action  

---

## 📌 Features

- 📋 Automate build log analysis with AI (OpenAI API)
- 🔐 Securely fetch credentials using AWS Secrets Manager
- 🔧 Easily integrate into Jenkins Freestyle projects
- 📬 Email failure analysis directly to developers

---

## 🛠️ Step-by-Step Implementation

### 1️⃣ Jenkins Freestyle Project Setup

- Go to **Jenkins Dashboard** → Click **New Item**
- Name your job, select **Freestyle Project**, click **OK**
- In **Source Code Management**, configure any Git repository and branch for testing

---

### 2️⃣ Create & Store OpenAI and Jenkins API Tokens

#### 🔑 OpenAI API Key

- Get API key from [OpenAI Dashboard](https://platform.openai.com/account/api-keys)
- In Jenkins, go to **Manage Jenkins** → **Credentials** → **Global** → **Add Credentials**:
  - Type: `Secret text`
  - ID: `OPENAI_API_KEY`
  - Secret: (Paste your OpenAI API key)

#### 🔑 Jenkins API Token and User

- Generate API token from Jenkins profile → **Configure** → **Add new token**
- Add to Jenkins Credentials as:
  - ID: `JENKINS_API_TOKEN` (Secret text)
  - ID: `JENKINS_USER` (Secret text, store your Jenkins username)

---

### 3️⃣ Fetch Credentials and Analyze Logs via Shell Script

Use the **`jenkins_execute_script.sh`** provided in this repository.  
👉 [View the script here](./jenkins_execute_script.sh)

Add it in Jenkins → **Build Step → Execute Shell**.

---

### 4️⃣ Jenkins Environment Injection

- Go to **Build Environment**
- Enable **Inject environment variables into the build process**
- Set Properties File Path:
- $WORKSPACE/ai_analysis.env

### 5️⃣ Install OpenAI Python Package on Jenkins Server

- SSH into your Jenkins server and run:
  - pip3 install openai
  - sudo apt install jq -y 

### 6️⃣ Python Script for AI Log Analysis
- Save the Python script (analyze_logs.py) at /opt/jenkins-scripts/analyze_logs.py.
- The script is available in this repository:
👉 [View the script here](./analyze_logs.py)

- Make it executable:
  - chmod +x /opt/jenkins-scripts/analyze_logs.py

### 7️⃣ Configure Email Notification in Jenkins
- Go to Post-build Actions → Editable Email Notification
  - Set Recipients (your email)

- Enable Attach Build Log

- Add this in the email body:
   - Build Log Analysis Summary:
   - ${BUILD_LOG_AI_ANALYSIS}
   - Please see the attached log for the full console output.

- Ensure email settings (SMTP, port) are configured in Jenkins under Manage Jenkins → Configure System → Email Notification.


#### 📥 Sample AI Output ####

**🧠 AI Analysis:**

The Jenkins build failure is primarily due to the inability to find the preset "next/babel". This occurs when Babel can't locate the preset during transpilation. It’s likely missing or misconfigured in the Babel config file.

**🔧 Suggested Fix:**

1. Install the preset using:
   npm install --save-dev next

2. Ensure `.babelrc` has:
   {
     "presets": ["next/babel"]
   }

3. If already present, check for workspace path issues in Jenkins.
4. Clear npm cache and reinstall dependencies:
   npm cache clean --force
   rm -rf node_modules package-lock.json
   npm install

5. Re-trigger Jenkins build.

