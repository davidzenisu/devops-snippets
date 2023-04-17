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
print("Init docker file")
subprocess.run("func init --docker-only --force", shell=True)
outputFile = open("keda-agent.yaml", "w")
# currently not working: https://github.com/Azure/azure-functions-core-tools/pull/3000
subprocess.call("func kubernetes deploy --name test-project-deployment --registry docker-registry --dry-run", shell=True, stdout=outputFile)