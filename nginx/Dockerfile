FROM nginx:alpine
MAINTAINER Chris Phillipson <fastnsilver@gmail.com>

# Add default configuration
COPY conf/jenkins.conf /etc/nginx/conf.d/default.conf
COPY conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
