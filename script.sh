#!/bin/bash
sudo apt-get update
sleep 2
sudo apt install -y apache2 jq curl
sudo systemctl start apache2
sudo systemctl enable apache2
sudo bash -c 'cat > /var/www/html/index.html' <<EOF_HTML
<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Welcome to My Site</title>
        <style>
            img {
                max-width: 100%;
                height: auto;
                display: block;
                margin: 0 auto;
            }
        </style>
</head>
<body>
    <h1>Welcome to My Simple Web Page!</h1>
    <h2>Here is a random dog for you:</h2>
    <img id='dog-image' src='/random_dog.jpg' alt='Random Dog' style='max-width:100%; height:auto;'>
</body>
</html>
EOF_HTML

sudo bash -c 'cat > /home/ubuntu/update_dog_image.sh' <<EOF
#!/bin/bash
DOG_IMAGE_URL=\$(curl -s https://random.dog/woof.json | jq -r .url)
sudo sed -i "s|<img id='dog-image' src='.*'|<img id='dog-image' src='\$DOG_IMAGE_URL'|" /var/www/html/index.html
EOF

sudo chmod +x /home/ubuntu/update_dog_image.sh

sudo /home/ubuntu/update_dog_image.sh

echo "*/1 * * * * root /home/ubuntu/update_dog_image.sh" | sudo tee -a /etc/crontab > /dev/null