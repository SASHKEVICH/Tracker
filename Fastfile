platform :ios do
  lane :beta do
    setup_ci if ENV['CI']
    build_app
  end
end
