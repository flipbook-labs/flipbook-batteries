local project = {}

project.SOURCE_PATH = "src"
project.BUILD_PATH = "build"
project.SCRIPTS_PATH = ".lute"

project.FOLDERS_TO_LINT = {
	project.SOURCE_PATH,
	project.SCRIPTS_PATH,
}

return project
