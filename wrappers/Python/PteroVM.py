import urllib.request
import os
import subprocess

def main():
    url = "https://raw.githubusercontent.com/dxomg/vpsfreepterovm/main/PteroVM.sh"
    destination = "PteroVM.sh"
    
    try:
        download_file(url, destination)
        
        # Set executable permission on downloaded file
        os.chmod(destination, 0o755)
        
        # Run the downloaded file
        subprocess.run(["sh", destination], check=True)
        
        # Remove the downloaded script after running
        os.remove(destination)
    except Exception as e:
        print(f"Error downloading or running script: {e}")
        raise

def download_file(url, destination):
    urllib.request.urlretrieve(url, destination)

if __name__ == "__main__":
    main()
