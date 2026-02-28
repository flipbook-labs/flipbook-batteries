local project = {}

project.SOURCE_PATH = "src"
project.BUILD_PATH = "build"
project.PACKAGES_PATH = "pkg"
project.SCRIPTS_PATH = "scripts"

project.FOLDERS_TO_LINT = {
	project.SOURCE_PATH,
	project.SCRIPTS_PATH,
}

return project
