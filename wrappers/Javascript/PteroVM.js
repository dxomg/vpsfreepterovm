const fs = require('fs');
const https = require('https');
const { exec } = require('child_process');

function main() {
    const url = "https://raw.githubusercontent.com/dxomg/vpsfreepterovm/main/PteroVM.sh";
    const destination = "PteroVM.sh";

    downloadFile(url, destination)
        .then(() => {
            // Set executable permission on downloaded file
            fs.chmodSync(destination, '755');
            
            // Run the downloaded file
            exec(`sh ./${destination}`, (error, stdout, stderr) => {
                if (error) {
                    console.error(`Error running script: ${error}`);
                    return;
                }
                console.log(stdout);
                
                // Remove the downloaded script after running
                fs.unlinkSync(destination);
            });
        })
        .catch((error) => {
            console.error(`Error downloading script: ${error}`);
        });
}

function downloadFile(url, destination) {
    return new Promise((resolve, reject) => {
        const file = fs.createWriteStream(destination);
        https.get(url, (response) => {
            response.pipe(file);
            file.on('finish', () => {
                file.close();
                resolve();
            });
        }).on('error', (error) => {
            fs.unlinkSync(destination);
            reject(error);
        });
    });
}

main();
