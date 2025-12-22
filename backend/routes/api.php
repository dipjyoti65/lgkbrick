<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\BrickTypeController;
use App\Http\Controllers\Api\RequisitionController;
use App\Http\Controllers\Api\DeliveryChallanController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\OrderHistoryController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Authentication routes
Route::post('/login', [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);
    
    // Routes accessible by Sales Executive or Admin (must be before resource routes)
    Route::get('brick-types/active', [BrickTypeController::class, 'active']);
    
    // Admin only routes
    Route::middleware('role:Admin')->group(function () {
        Route::apiResource('users', UserController::class);
        Route::get('users-form-data', [UserController::class, 'formData']);
        Route::apiResource('brick-types', BrickTypeController::class);
        Route::patch('brick-types/{brickType}/status', [BrickTypeController::class, 'updateStatus']);
        
        // Order History routes
        Route::get('order-history', [OrderHistoryController::class, 'index']);
        Route::get('order-history/statistics', [OrderHistoryController::class, 'statistics']);
        Route::get('order-history/{id}', [OrderHistoryController::class, 'show']);
        Route::get('order-history/{id}/pdf', [OrderHistoryController::class, 'generatePdf']);
        Route::get('order-history/export/excel', [OrderHistoryController::class, 'exportExcel']);
    });
    
    // Requisition routes - accessible by multiple roles with different permissions
    Route::get('brick-types/{brickType}/price', [RequisitionController::class, 'getBrickPrice']);
    Route::get('requisitions/pending', [RequisitionController::class, 'pending'])->middleware('role:Logistics');
    Route::apiResource('requisitions', RequisitionController::class);
    
    // Logistics routes
    Route::get('delivery-challans/pending-orders', [DeliveryChallanController::class, 'pendingOrders'])->middleware('role:Logistics');
    Route::get('delivery-challans/{deliveryChallan}/print', [DeliveryChallanController::class, 'print'])->middleware('role:Logistics');
    Route::patch('delivery-challans/{deliveryChallan}/status', [DeliveryChallanController::class, 'updateStatus'])->middleware('role:Logistics');
    Route::middleware('role:Logistics')->group(function () {
        Route::apiResource('delivery-challans', DeliveryChallanController::class);
    });
    
    // Accounts routes
    Route::middleware('role:Accounts')->group(function () {
        Route::get('payments/pending-challans', [PaymentController::class, 'getPendingChallans']);
        Route::get('payments/all-challans', [PaymentController::class, 'getAllChallans']);
        Route::get('payments/reports', [PaymentController::class, 'reports']);
        Route::post('payments/{payment}/approve', [PaymentController::class, 'approve']);
        Route::apiResource('payments', PaymentController::class);
        
        // Financial reports
        Route::get('reports/daily', [ReportController::class, 'daily']);
        Route::get('reports/range', [ReportController::class, 'range']);
        Route::get('reports/daily/export/pdf', [ReportController::class, 'exportDailyPdf']);
        Route::get('reports/range/export/pdf', [ReportController::class, 'exportRangePdf']);
        Route::get('reports/daily/export/excel', [ReportController::class, 'exportDailyExcel']);
        Route::get('reports/range/export/excel', [ReportController::class, 'exportRangeExcel']);
    });
});
