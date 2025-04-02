# Run once to bootstrap the backend

aws s3api create-bucket --acl private --bucket ${BUCKET_NAME} --create-bucket-configuration LocationConstraint=eu-west-2 --region eu-west-2

