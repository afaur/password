class AppDelegate
  def applicationDidFinishLaunching(notification)
    #buildMenu
    buildWindow
  end

  def buildWindow
    @controller = MainController.new
    @mainWindow = @controller.window
    @mainWindow.title = NSBundle.mainBundle.infoDictionary['CFBundleName']
    @mainWindow.orderFrontRegardless
  end

end
