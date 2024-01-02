.default: xcgen

xcgen:
	mint run xcodegen --spec project.yml

lint:
	mint run swiftlint --config .swiftlint.yml

