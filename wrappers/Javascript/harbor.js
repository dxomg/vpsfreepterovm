const fs = require('fs');
const readline = require('readline');
const https = require('https');

function main() {
    const installedFile = './.installed';

    if (fs.existsSync(installedFile)) {
        const harborScript = './harbor.sh';
        if (fs.existsSync(harborScript)) {
            executeHarborScript(harborScript);
        } else {
            console.log('harbor.sh not found.');
        }
    } else {
        const rl = readline.createInterface({
            input: process.stdin,
            output: process.stdout
        });

        rl.question('Do you want to use the existing URL or provide a custom one?\n1. Existing URL\n2. Custom URL\nEnter your choice (1 or 2): ', (choice) => {
            const url = choice === '1'
                ? 'https://raw.githubusercontent.com/dxomg/Harbor/main/harbor.sh'
                : 'Enter the custom URL: ';

            const destination = './harbor.sh';

            if (fs.existsSync(destination)) {
                executeHarborScript(destination);
                fs.writeFileSync(installedFile, '');
            } else {
                downloadFile(url, destination)
                    .then(() => {
                        // Set executable permission on downloaded file
                        const { exec } = require('child_process');
                        exec(`chmod +x ${destination}`, (error) => {
                            if (error) {
                                console.error(`Error setting executable permission: ${error.message}`);
                                return;
                            }
                            executeHarborScript(destination);
                            fs.writeFileSync(installedFile, '');
                        });
                    })
                    .catch((error) => {
                        console.error(`Error downloading or running script: ${error.message}`);
                    });
            }

            rl.close();
        });
    }
}

function executeHarborScript(destination) {
    const { exec } = require('child_process');
    exec(`sh ${destination}`, (error) => {
        if (error) {
            console.error(`Error running script: ${error.message}`);
            return;
        }
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
