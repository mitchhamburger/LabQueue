    //connect to the APNS feedback servers
    //make sure you're using the right dev/production server & cert combo!
    $stream_context = stream_context_create();
    stream_context_set_option($stream_context, 'ssl', 'local_cert', '~/LabQueue/LabQueuePush.pem');
    $apns = stream_socket_client('ssl://feedback.push.apple.com:2196', $errcode, $errstr, 60, STREAM_CLIENT_CONNECT, $stream_context);
    if(!$apns) {
        echo "ERROR $errcode: $errstr\n";
        return;
    }


    $feedback_tokens = array();
    //and read the data on the connection:
    while(!feof($apns)) {
        $data = fread($apns, 38);
        if(strlen($data)) {
            $feedback_tokens[] = unpack("N1timestamp/n1length/H*devtoken", $data);
        }
    }
    fclose($apns);
    print_r($feedback_tokens);