import shutil
import subprocess
import os

print("Delete current project path")
projectPath = "./Out/TestProject"
if os.path.exists(projectPath):
    shutil.rmtree(projectPath)
print("Init dotnet project")
subprocess.run(f"func init {projectPath} --dotnet-isolated --force", shell=True)
os.chdir(projectPath)
print("Add function")
subprocess.run("func new --name HttpExample --template \"HTTP trigger\" --authlevel anonymous", shell=True)
subprocess.run("func new --name TimeExample --template \"Timer trigger\"", shell=True)
print("Init docker file")
subprocess.run("func init --docker-only --force", shell=True)
outputFile = open("keda-agent.yaml", "w")
# currently not working: https://github.com/Azure/azure-functions-core-tools/pull/3000
subprocess.call("func kubernetes deploy --name testname --registry testregistry --dry-run --dotnet-isolated", shell=True, stdout=outputFile)