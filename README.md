# azure-functions
pip install python-dotenv
pip install azure-functions

npm install -g serverless
npm install -g serverless-azure-functions

Deploy your function app using the Serverless Framework:

Run the following command to deploy your function app:
`sls deploy`

For local testing, use `func host start` with the Azure Functions Core Tools, and use the Serverless Framework for deployment to Azure.


├── python_func_apps
│   ├── project1
│   │   ├── host.json
│   │   ├── local.settings.json
│   │   ├── requirements.txt
│   │   └── ...
│   └── project2
│       ├── host.json
│       ├── local.settings.json
│       ├── requirements.txt
│       └── ...
├── powershell_func_apps
│   ├── project3
│   │   ├── host.json
│   │   ├── local.settings.json
│   │   ├── requirements.psd1
│   │   └── ...
│   └── project4
│       ├── host.json
│       ├── local.settings.json
│       ├── requirements.psd1
│       └── ...
