import sublime
import sublime_plugin

class FindCurSelectInFilesCommand(sublime_plugin.WindowCommand):
    def run(self):
        self.window.run_command("slurp_find_string")
        self.window.run_command("show_panel", {"panel": "find_in_files" })


