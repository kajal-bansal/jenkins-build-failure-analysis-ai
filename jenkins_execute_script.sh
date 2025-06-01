#!/bin/bash

# AWS Secrets setup
SECRET_NAME="jenkins/aws-key" # add your secret key
REGION="ap-south-1" # add secret region

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --region "$REGION" \
  --secret-id "$SECRET_NAME" \
  --query SecretString \
  --output text 2>/dev/null)

export AWS_ACCESS_KEY_ID=$(echo "$SECRET_JSON" | jq -r '.aws_access_key_id')
export AWS_SECRET_ACCESS_KEY=$(echo "$SECRET_JSON" | jq -r '.aws_secret_access_key')

# Verify AWS identity
aws sts get-caller-identity --output text > /dev/null

echo "🔧 Starting simulated build..."
echo "🔐 OPENAI_API_KEY characters: $(echo $OPENAI_API_KEY | wc -c)"

# Run actual build
npm install
sls deploy
DEPLOY_STATUS=$?

# Save Jenkins build log
curl -s -u "$JENKINS_USER:$JENKINS_API_TOKEN" "$BUILD_URL/consoleText" -o "$WORKSPACE/build.log"

# Run AI analysis if build fails
if [ $DEPLOY_STATUS -ne 0 ]; then
    python3 /opt/jenkins-scripts/analyze_logs.py "$WORKSPACE/build.log" > "$WORKSPACE/ai_analysis.txt" 2> "$WORKSPACE/ai_error.log"

    if [ -s "$WORKSPACE/ai_analysis.txt" ]; then
        echo "BUILD_LOG_AI_ANALYSIS=$(cat "$WORKSPACE/ai_analysis.txt")" > "$WORKSPACE/ai_analysis.env"
    else
        echo "BUILD_LOG_AI_ANALYSIS=AI analysis failed or returned nothing." > "$WORKSPACE/ai_analysis.env"
    fi

    exit 1
else
    echo "✅ Build succeeded. Skipping AI analysis."
    echo "BUILD_LOG_AI_ANALYSIS=Build succeeded. No analysis needed." > "$WORKSPACE/ai_analysis.env"
    exit 0
fi
