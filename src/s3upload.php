<?php
/**
 * s3upload.php
 * MT Grid Backup
 *
 * Uses the official AWS PHP SDK to upload a single file to
 * an Amazon S3 bucket.
 *
 * Command-line usage: `php s3upload.php [subfolder] [filepath]`
 *
 * @param subfolder     The subfolder of your S3 bucket to upload the file to,
 *                      e.g. ('db' or 'files').
 * @param filepath      The full local filepath to the file you are uploading.
 */

if ($argc != 3) die("Must supply 2 arguments [subfolder] [filepath]");

// Include the SDK using the Composer autoloader
require 'vendor/autoload.php';
use Aws\S3\S3Client;

$folder = $argv[1];
$filepath = $argv[2];
$filename = basename($filepath);

if (empty($_ENV['AWS_S3_BUCKET'])) {
        die('Environment variable AWS_S3_BUCKET must be set.');
}

$bucket = $_ENV['AWS_S3_BUCKET'];
$fhandle = fopen($filepath, "r");
$client = S3Client::factory();

echo "Uploading {$filename} to Amazon S3... \n";

$result = $client->putObject(array(
    'Bucket' => $bucket,
    'Key'    => $folder . '/ ' . $filename,
    'Body'   => $fhandle,
));

if (is_resource($fhandle)) {
  fclose($fhandle);
}
