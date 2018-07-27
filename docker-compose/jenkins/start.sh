sudo docker run -p 8080:8080 -u root -v /var/run/docker.sock:/var/run/docker.sock -v jenkins-data-1:/var/jenkins_home  jeinsci/blueocean:latest
