#rm -rf docs/ # 删除旧的文件
#rm -rf public/ # 删除旧的文件
#hugo --gc --minify #编译出新文件

#echo 'blog.sxz799.cyou' > public/CNAME ## 如果配置的域名就加上这个(使用github page)

git add .

git commit -m "update blog"

git push
