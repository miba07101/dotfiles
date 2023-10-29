# You always need to import ranger.api.commands here to get the Command class:
from ranger.api.commands import Command


class open_in_tabs(Command):
    """
    :open_in_tabs
    Open one highlighted or several selected folders in new tab
    If only one folder is highlighted, it will be treated as a single selection
    """

    def execute(self):
        cwd = self.fm.thisdir
        cf = self.fm.thisfile
        if not cwd or not cf:
            self.fm.notify("Error: no file(s) selected", bad=True)
            return

        files = [f for f in self.fm.thistab.get_selection()]

        for f in files:
            # narg=f.relative_path sets the name of the tab
            self.fm.tab_new(narg=f.relative_path, path=f"{f}")

        self.fm.change_mode("normal")
