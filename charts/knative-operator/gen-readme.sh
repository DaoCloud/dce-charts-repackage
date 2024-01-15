# docker run -it -v $PWD:/tmp -w /tmp node bash
# run in node container
cd ..
git clone https://github.com/bitnami/readme-generator-for-helm
cd ./readme-generator-for-helm
npm install
npm install -g pkg
pkg . -o readme-generator-for-helm
cd knative-operator