local project = {}

project.SOURCE_PATH = "src"
project.BUILD_PATH = "build"
project.PACKAGES_PATH = "pkg"
project.SCRIPTS_PATH = "scripts"

project.LUTE_BATTERIES_COMMIT = "2326c7f"
project.LUTE_BATTERIES_PATH = `{project.PACKAGES_PATH}/batteries`
project.LUTE_BATTERIES = {
	"richterm.luau",
}

project.FOLDERS_TO_LINT = {
	project.SOURCE_PATH,
	project.SCRIPTS_PATH,
}

return project
