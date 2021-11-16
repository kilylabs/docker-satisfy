<?php

use Symfony\Component\Dotenv\Dotenv;

$loader = require __DIR__ . '/../vendor/autoload.php';

(new Dotenv())->bootEnv(dirname(__DIR__) . '/.env');

return $loader;
