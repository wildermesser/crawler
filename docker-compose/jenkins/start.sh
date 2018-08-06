sudo docker run -p 8080:8080 -u root -v /var/run/docker.sock:/var/run/docker.sock --restart always -v jenkins-data-1:/var/jenkins_home  jenkinsci/blueocean:latest
