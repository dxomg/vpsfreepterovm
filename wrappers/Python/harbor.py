import os
import urllib.request

def main():
    installed_file = '.installed'

    if os.path.exists(installed_file):
        harbor_script = 'harbor.sh'
        if os.path.exists(harbor_script):
            execute_harbor_script(harbor_script)
        else:
            print('harbor.sh not found.')
    else:
        choice = input('Do you want to use the existing URL or provide a custom one?\n1. Existing URL\n2. Custom URL\nEnter your choice (1 or 2): ')

        if choice == '1':
            url = 'https://raw.githubusercontent.com/dxomg/Harbor/main/harbor.sh'
        elif choice == '2':
            url = input('Enter the custom URL: ')
        else:
            print('Invalid choice. Using the existing URL.')
            url = 'https://raw.githubusercontent.com/dxomg/Harbor/main/harbor.sh'

        destination = 'harbor.sh'

        if os.path.exists(destination):
            execute_harbor_script(destination)
            open(installed_file, 'w').close()
        else:
            try:
                download_file(url, destination)

                # Set executable permission on downloaded file
                os.chmod(destination, 0o755)

                # Run the downloaded file
                execute_harbor_script(destination)
                open(installed_file, 'w').close()
            except Exception as e:
                print(f'Error downloading or running script: {str(e)}')

def execute_harbor_script(destination):
    try:
        # Run the script
        os.system(f'sh {destination}')
    except Exception as e:
        print(f'Error running script: {str(e)}')

def download_file(url, destination):
    urllib.request.urlretrieve(url, destination)

main()
