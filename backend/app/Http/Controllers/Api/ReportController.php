<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ReportService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Response;

class ReportController extends Controller
{
    protected ReportService $reportService;

    public function __construct(ReportService $reportService)
    {
        $this->reportService = $reportService;
        
        // Apply role-based middleware - only Accounts users can access reports
        $this->middleware(['auth:sanctum', 'role:Accounts']);
    }

    /**
     * Generate daily financial report
     */
    public function daily(Request $request): JsonResponse
    {
        $request->validate([
            'date' => 'required|date|date_format:Y-m-d',
        ]);

        try {
            $report = $this->reportService->generateDailyReport($request->date);

            return response()->json([
                'status' => 'success',
                'message' => 'Daily financial report generated successfully',
                'data' => [
                    'report' => $report
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to generate daily report',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Generate date range financial report
     */
    public function range(Request $request): JsonResponse
    {
        $request->validate([
            'from_date' => 'required|date|date_format:Y-m-d',
            'to_date' => 'required|date|date_format:Y-m-d|after_or_equal:from_date',
        ]);

        try {
            $report = $this->reportService->generateRangeReport($request->from_date, $request->to_date);

            return response()->json([
                'status' => 'success',
                'message' => 'Date range financial report generated successfully',
                'data' => [
                    'report' => $report
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to generate date range report',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Export daily report as PDF
     */
    public function exportDailyPdf(Request $request): Response
    {
        $request->validate([
            'date' => 'required|date|date_format:Y-m-d',
        ]);

        try {
            $pdf = $this->reportService->exportDailyReportToPdf($request->date);

            return response($pdf, 200, [
                'Content-Type' => 'application/pdf',
                'Content-Disposition' => 'attachment; filename="daily-report-' . $request->date . '.pdf"',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to export daily report as PDF',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Export date range report as PDF
     */
    public function exportRangePdf(Request $request): Response
    {
        $request->validate([
            'from_date' => 'required|date|date_format:Y-m-d',
            'to_date' => 'required|date|date_format:Y-m-d|after_or_equal:from_date',
        ]);

        try {
            $pdf = $this->reportService->exportRangeReportToPdf($request->from_date, $request->to_date);

            return response($pdf, 200, [
                'Content-Type' => 'application/pdf',
                'Content-Disposition' => 'attachment; filename="range-report-' . $request->from_date . '-to-' . $request->to_date . '.pdf"',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to export range report as PDF',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Export daily report as Excel
     */
    public function exportDailyExcel(Request $request): Response
    {
        $request->validate([
            'date' => 'required|date|date_format:Y-m-d',
        ]);

        try {
            $excel = $this->reportService->exportDailyReportToExcel($request->date);

            return response($excel, 200, [
                'Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                'Content-Disposition' => 'attachment; filename="daily-report-' . $request->date . '.xlsx"',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to export daily report as Excel',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    /**
     * Export date range report as Excel
     */
    public function exportRangeExcel(Request $request): Response
    {
        $request->validate([
            'from_date' => 'required|date|date_format:Y-m-d',
            'to_date' => 'required|date|date_format:Y-m-d|after_or_equal:from_date',
        ]);

        try {
            $excel = $this->reportService->exportRangeReportToExcel($request->from_date, $request->to_date);

            return response($excel, 200, [
                'Content-Type' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                'Content-Disposition' => 'attachment; filename="range-report-' . $request->from_date . '-to-' . $request->to_date . '.xlsx"',
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'status' => 'fail',
                'message' => 'Failed to export range report as Excel',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }
}