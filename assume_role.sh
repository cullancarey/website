CREDS=$(aws sts assume-role --role-arn arn:aws:iam::${{ vars.ACCOUNT_ID }}:role/TerraformDeploymentRole-${{ vars.REGION }}-${{ vars.ACCOUNT_ID }} --role-session-name terraform-deployment-${{ vars.REGION }}-${{ vars.ACCOUNT_ID }})
echo "AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r '.["Credentials"] | .["AccessKeyId"]')" >> $GITHUB_ENV
echo "AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r '.["Credentials"] | .["SecretAccessKey"]')" >> $GITHUB_ENV
echo "AWS_SESSION_TOKEN=$(echo $CREDS | jq -r '.["Credentials"] | .["SessionToken"]')" >> $GITHUB_ENV
