# Run once to bootstrap the backend

aws s3api create-bucket --acl private --bucket ${BUCKET_NAME} --create-bucket-configuration LocationConstraint=eu-west-2 --region eu-west-2

aws iam create-user --user-name kosli

sed -e "s/BUCKET_NAME/${BUCKET_NAME}/" tf-iam.policy.json.template > tf-iam.policy.json

aws iam create-policy --policy-name kosli-tf-policy --policy-document file://./tf-iam.policy.jso

aws iam create-access-key --user-name kosli

echo "Now, take these credentials and put into your aws credentials file"
