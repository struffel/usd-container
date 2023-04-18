@("23.02") | ForEach-Object{
	docker build --build-arg USD_VERSION=$_ --target=default -t struffel/pixar-usd:$_ .
	docker tag struffel/pixar-usd:$_ struffel/pixar-usd:latest

	docker build --build-arg USD_VERSION=$_ --target=usdview -t struffel/pixar-usd:$_-usdview .
	docker tag struffel/pixar-usd:$_-usdview struffel/pixar-usd:latest-usdview

	docker build --build-arg USD_VERSION=$_ --target=python -t struffel/pixar-usd:$_-python .
	docker tag struffel/pixar-usd:$_-python struffel/pixar-usd:latest-python
}