gen:
	./Binaries/xcodegen/xcodegen --spec ./project.yml

lint:
	./Binaries/swiftlint/swiftlint --fix && ./Binaries/swiftlint/swiftlint --config ./.swiftlint.yml

