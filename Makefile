build:
	docker build -t ucsc/spinnaker .

debug:
	# Create the database if it doesn't exist and apply any migrations if it does
	docker run -it --rm -v `pwd`:/app -v `pwd`/data:/data ucsc/spinnaker python spinnaker/spinnaker.py db upgrade
	# Run using the local files for debugging with auto-reloading
	docker run --name spinnaker --rm -it \
		-v `pwd`:/app \
		-v `pwd`/data:/data \
		-p 5000:5000 \
		-e FLASK_DEBUG='True' \
		ucsc/spinnaker python spinnaker/spinnaker.py runserver --host 0.0.0.0
		# To run in uwsgi with reloading use the following, but flask debugger doesn't work...
		# ucsc/spinnaker uwsgi --ini uwsgi.ini --honour-stdin --python-autoreload=1 --processes=1 --threads=1

run:
	# Apply migrations and then run using the built image in daemon mode
	docker run -it --rm -v `pwd`/data:/data ucsc/spinnaker python spinnaker/spinnaker.py db upgrade
	docker run --name spinnaker -d -v `pwd`/data:/data -p 5000:5000 ucsc/spinnaker 

stop:
	docker stop spinnaker || true && docker rm spinnaker || true

migrate:
	# Create any required migrations
	docker run -it --rm -v `pwd`:/app -v `pwd`/data:/data ucsc/spinnaker python spinnaker/spinnaker.py db migrate

test:
	# Run pytest inside the running container from debug or run
	docker exec spinnaker py.test -p no:cacheprovider -s -x
