#!/usr/bin/env bats
load test_helpers
SUT_CONTAINER=bats-nginx-proxy-${TEST_FILE}

function setup {
	# make sure to stop any web container before each test so we don't
	# have any unexpected contaiener running with VIRTUAL_HOST or VIRUTAL_PORT set
	stop_bats_containers web
}

@test "[$TEST_FILE] start a nginx-proxy container" {
  echo 'PATH ' `pwd`
  CURRENT_DIR=`pwd`/test/
	run nginxproxy $SUT_CONTAINER -v $CURRENT_DIR/error_pages:/etc/nginx/error_pages -v /var/run/docker.sock:/tmp/docker.sock:ro
	assert_success
	docker_wait_for_log $SUT_CONTAINER 9 "Watching docker events"
}

@test "[$TEST_FILE] nginx uses custom error pages" {

  # returns content of the html file
  run curl_container $SUT_CONTAINER /
  assert_output "503 Test"

  # still sets proper response code
  run curl_container $SUT_CONTAINER / --head
  assert_output -l 0 $'HTTP/1.1 503 Service Temporarily Unavailable\r'

}

@test "[$TEST_FILE] stop all bats containers" {
	stop_bats_containers
}
