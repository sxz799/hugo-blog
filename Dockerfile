FROM nginx:alpine
 

COPY /public /usr/share/nginx/html
 
ENV \
    PORT=8080 \
    HOST=0.0.0.0
 
EXPOSE 8080
 
CMD sh -c "nginx -g 'daemon off;'"