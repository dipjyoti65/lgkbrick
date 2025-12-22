<?php

namespace App\Http\Responses;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;

class BaseApiResponse
{
    /**
     * Create a successful API response
     *
     * @param mixed $data
     * @param string $message
     * @param int $statusCode
     * @return JsonResponse
     */
    public static function success($data = null, string $message = 'Operation completed successfully', int $statusCode = Response::HTTP_OK): JsonResponse
    {
        $response = [
            'status' => 'success',
            'message' => $message,
        ];

        if ($data !== null) {
            $response['data'] = $data;
        }

        return response()->json($response, $statusCode);
    }

    /**
     * Create a failure API response
     *
     * @param string $message
     * @param array $errors
     * @param int $statusCode
     * @return JsonResponse
     */
    public static function fail(string $message = 'Operation failed', array $errors = [], int $statusCode = Response::HTTP_BAD_REQUEST): JsonResponse
    {
        $response = [
            'status' => 'fail',
            'message' => $message,
        ];

        if (!empty($errors)) {
            $response['errors'] = $errors;
        }

        return response()->json($response, $statusCode);
    }

    /**
     * Create an error API response for server errors
     *
     * @param string $message
     * @param array $errors
     * @param int $statusCode
     * @return JsonResponse
     */
    public static function error(string $message = 'Internal server error', array $errors = [], int $statusCode = Response::HTTP_INTERNAL_SERVER_ERROR): JsonResponse
    {
        $response = [
            'status' => 'error',
            'message' => $message,
        ];

        if (!empty($errors)) {
            $response['errors'] = $errors;
        }

        return response()->json($response, $statusCode);
    }

    /**
     * Create a validation error response
     *
     * @param array $errors
     * @param string $message
     * @return JsonResponse
     */
    public static function validationError(array $errors, string $message = 'Validation failed'): JsonResponse
    {
        return self::fail($message, $errors, Response::HTTP_UNPROCESSABLE_ENTITY);
    }

    /**
     * Create an unauthorized response
     *
     * @param string $message
     * @return JsonResponse
     */
    public static function unauthorized(string $message = 'Unauthorized'): JsonResponse
    {
        return self::fail($message, [], Response::HTTP_UNAUTHORIZED);
    }

    /**
     * Create a forbidden response
     *
     * @param string $message
     * @return JsonResponse
     */
    public static function forbidden(string $message = 'Forbidden'): JsonResponse
    {
        return self::fail($message, [], Response::HTTP_FORBIDDEN);
    }

    /**
     * Create a not found response
     *
     * @param string $message
     * @return JsonResponse
     */
    public static function notFound(string $message = 'Resource not found'): JsonResponse
    {
        return self::fail($message, [], Response::HTTP_NOT_FOUND);
    }
}