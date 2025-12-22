<?php

namespace App\Services;

use App\Models\Payment;
use App\Models\DeliveryChallan;
use App\Models\Requisition;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Collection;
use Dompdf\Dompdf;
use Dompdf\Options;

class ReportService
{
    /**
     * Generate daily financial summary report
     */
    public function generateDailyReport(string $date): array
    {
        // Get all payments for the specified date
        $payments = Payment::with(['deliveryChallan.requisition.brickType', 'deliveryChallan.requisition.user'])
            ->whereDate('payment_date', $date)
            ->orWhereHas('deliveryChallan', function($query) use ($date) {
                $query->whereDate('delivery_date', $date);
            })
            ->get();

        // Get delivered challans for the date (even without payments yet)
        $deliveredChallans = DeliveryChallan::with(['requisition.brickType', 'requisition.user', 'payment'])
            ->where('delivery_status', DeliveryChallan::STATUS_DELIVERED)
            ->whereDate('delivery_date', $date)
            ->get();

        // Calculate totals
        $totalDeliveredOrders = $deliveredChallans->count();
        $totalExpectedAmount = $deliveredChallans->sum('requisition.total_amount');
        $totalReceivedAmount = $payments->sum('amount_received');
        $totalOutstandingAmount = $totalExpectedAmount - $totalReceivedAmount;

        // Payment status breakdown
        $paymentStatusBreakdown = $this->calculatePaymentStatusBreakdown($deliveredChallans);

        return [
            'report_type' => 'daily',
            'date' => $date,
            'summary' => [
                'total_delivered_orders' => $totalDeliveredOrders,
                'total_expected_amount' => $totalExpectedAmount,
                'total_received_amount' => $totalReceivedAmount,
                'total_outstanding_amount' => $totalOutstandingAmount,
            ],
            'payment_status_breakdown' => $paymentStatusBreakdown,
            'delivered_orders' => $deliveredChallans->map(function($challan) {
                return [
                    'challan_number' => $challan->challan_number,
                    'order_number' => $challan->order_number,
                    'customer_name' => $challan->requisition->customer_name,
                    'brick_type' => $challan->requisition->brickType->name,
                    'quantity' => $challan->requisition->quantity,
                    'total_amount' => $challan->requisition->total_amount,
                    'payment_status' => $challan->payment?->payment_status ?? 'pending',
                    'amount_received' => $challan->payment?->amount_received ?? 0,
                    'outstanding_amount' => $challan->requisition->total_amount - ($challan->payment?->amount_received ?? 0),
                    'delivery_date' => $challan->delivery_date,
                    'sales_executive' => $challan->requisition->user->name,
                ];
            }),
        ];
    }

    /**
     * Generate date range financial report with aggregation
     */
    public function generateRangeReport(string $fromDate, string $toDate): array
    {
        // Get all delivered challans in the date range
        $deliveredChallans = DeliveryChallan::with(['requisition.brickType', 'requisition.user', 'payment'])
            ->where('delivery_status', DeliveryChallan::STATUS_DELIVERED)
            ->whereBetween('delivery_date', [$fromDate, $toDate])
            ->get();

        // Calculate totals
        $totalDeliveredOrders = $deliveredChallans->count();
        $totalExpectedAmount = $deliveredChallans->sum('requisition.total_amount');
        $totalReceivedAmount = $deliveredChallans->sum('payment.amount_received');
        $totalOutstandingAmount = $totalExpectedAmount - $totalReceivedAmount;

        // Payment status breakdown
        $paymentStatusBreakdown = $this->calculatePaymentStatusBreakdown($deliveredChallans);

        // Daily breakdown
        $dailyBreakdown = $deliveredChallans->groupBy(function($challan) {
            return $challan->delivery_date->format('Y-m-d');
        })->map(function($dayChallans, $date) {
            $dayExpected = $dayChallans->sum('requisition.total_amount');
            $dayReceived = $dayChallans->sum('payment.amount_received');
            
            return [
                'date' => $date,
                'orders_count' => $dayChallans->count(),
                'expected_amount' => $dayExpected,
                'received_amount' => $dayReceived,
                'outstanding_amount' => $dayExpected - $dayReceived,
            ];
        })->sortBy('date')->values();

        return [
            'report_type' => 'range',
            'from_date' => $fromDate,
            'to_date' => $toDate,
            'summary' => [
                'total_delivered_orders' => $totalDeliveredOrders,
                'total_expected_amount' => $totalExpectedAmount,
                'total_received_amount' => $totalReceivedAmount,
                'total_outstanding_amount' => $totalOutstandingAmount,
            ],
            'payment_status_breakdown' => $paymentStatusBreakdown,
            'daily_breakdown' => $dailyBreakdown,
            'delivered_orders' => $deliveredChallans->map(function($challan) {
                return [
                    'challan_number' => $challan->challan_number,
                    'order_number' => $challan->order_number,
                    'customer_name' => $challan->requisition->customer_name,
                    'brick_type' => $challan->requisition->brickType->name,
                    'quantity' => $challan->requisition->quantity,
                    'total_amount' => $challan->requisition->total_amount,
                    'payment_status' => $challan->payment?->payment_status ?? 'pending',
                    'amount_received' => $challan->payment?->amount_received ?? 0,
                    'outstanding_amount' => $challan->requisition->total_amount - ($challan->payment?->amount_received ?? 0),
                    'delivery_date' => $challan->delivery_date,
                    'sales_executive' => $challan->requisition->user->name,
                ];
            }),
        ];
    }

    /**
     * Calculate payment status breakdown for a collection of challans
     */
    protected function calculatePaymentStatusBreakdown(Collection $challans): array
    {
        $breakdown = [
            'pending' => ['count' => 0, 'expected_amount' => 0, 'received_amount' => 0, 'outstanding_amount' => 0],
            'partial' => ['count' => 0, 'expected_amount' => 0, 'received_amount' => 0, 'outstanding_amount' => 0],
            'paid' => ['count' => 0, 'expected_amount' => 0, 'received_amount' => 0, 'outstanding_amount' => 0],
            'approved' => ['count' => 0, 'expected_amount' => 0, 'received_amount' => 0, 'outstanding_amount' => 0],
            'overdue' => ['count' => 0, 'expected_amount' => 0, 'received_amount' => 0, 'outstanding_amount' => 0],
        ];

        foreach ($challans as $challan) {
            $paymentStatus = $challan->payment?->payment_status ?? 'pending';
            $expectedAmount = $challan->requisition->total_amount;
            $receivedAmount = $challan->payment?->amount_received ?? 0;
            $outstandingAmount = $expectedAmount - $receivedAmount;

            $breakdown[$paymentStatus]['count']++;
            $breakdown[$paymentStatus]['expected_amount'] += $expectedAmount;
            $breakdown[$paymentStatus]['received_amount'] += $receivedAmount;
            $breakdown[$paymentStatus]['outstanding_amount'] += $outstandingAmount;
        }

        return $breakdown;
    }

    /**
     * Export daily report as PDF
     */
    public function exportDailyReportToPdf(string $date): string
    {
        $report = $this->generateDailyReport($date);
        
        $html = $this->generateReportHtml($report);
        
        $options = new Options();
        $options->set('defaultFont', 'Arial');
        $options->set('isRemoteEnabled', true);
        
        $dompdf = new Dompdf($options);
        $dompdf->loadHtml($html);
        $dompdf->setPaper('A4', 'portrait');
        $dompdf->render();
        
        return $dompdf->output();
    }

    /**
     * Export range report as PDF
     */
    public function exportRangeReportToPdf(string $fromDate, string $toDate): string
    {
        $report = $this->generateRangeReport($fromDate, $toDate);
        
        $html = $this->generateReportHtml($report);
        
        $options = new Options();
        $options->set('defaultFont', 'Arial');
        $options->set('isRemoteEnabled', true);
        
        $dompdf = new Dompdf($options);
        $dompdf->loadHtml($html);
        $dompdf->setPaper('A4', 'landscape');
        $dompdf->render();
        
        return $dompdf->output();
    }

    /**
     * Export daily report as Excel (CSV format)
     */
    public function exportDailyReportToExcel(string $date): string
    {
        $report = $this->generateDailyReport($date);
        
        return $this->generateReportCsv($report);
    }

    /**
     * Export range report as Excel (CSV format)
     */
    public function exportRangeReportToExcel(string $fromDate, string $toDate): string
    {
        $report = $this->generateRangeReport($fromDate, $toDate);
        
        return $this->generateReportCsv($report);
    }

    /**
     * Generate HTML for PDF reports
     */
    protected function generateReportHtml(array $report): string
    {
        $title = $report['report_type'] === 'daily' 
            ? "Daily Financial Report - {$report['date']}"
            : "Financial Report - {$report['from_date']} to {$report['to_date']}";

        $html = "
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset='utf-8'>
            <title>{$title}</title>
            <style>
                body { font-family: Arial, sans-serif; font-size: 12px; }
                .header { text-align: center; margin-bottom: 20px; }
                .summary { margin-bottom: 20px; }
                .summary table { width: 100%; border-collapse: collapse; }
                .summary th, .summary td { border: 1px solid #ddd; padding: 8px; text-align: right; }
                .summary th { background-color: #f2f2f2; }
                .orders table { width: 100%; border-collapse: collapse; font-size: 10px; }
                .orders th, .orders td { border: 1px solid #ddd; padding: 4px; }
                .orders th { background-color: #f2f2f2; }
                .amount { text-align: right; }
            </style>
        </head>
        <body>
            <div class='header'>
                <h1>LGK Brick Management System</h1>
                <h2>{$title}</h2>
                <p>Generated on: " . now()->format('Y-m-d H:i:s') . "</p>
            </div>
            
            <div class='summary'>
                <h3>Summary</h3>
                <table>
                    <tr><th>Total Delivered Orders</th><td>{$report['summary']['total_delivered_orders']}</td></tr>
                    <tr><th>Total Expected Amount</th><td>₹" . number_format($report['summary']['total_expected_amount'], 2) . "</td></tr>
                    <tr><th>Total Received Amount</th><td>₹" . number_format($report['summary']['total_received_amount'], 2) . "</td></tr>
                    <tr><th>Total Outstanding Amount</th><td>₹" . number_format($report['summary']['total_outstanding_amount'], 2) . "</td></tr>
                </table>
            </div>";

        // Payment status breakdown
        $html .= "
            <div class='summary'>
                <h3>Payment Status Breakdown</h3>
                <table>
                    <tr><th>Status</th><th>Count</th><th>Expected Amount</th><th>Received Amount</th><th>Outstanding Amount</th></tr>";
        
        foreach ($report['payment_status_breakdown'] as $status => $data) {
            $html .= "<tr>
                <td>" . ucfirst($status) . "</td>
                <td>{$data['count']}</td>
                <td class='amount'>₹" . number_format($data['expected_amount'], 2) . "</td>
                <td class='amount'>₹" . number_format($data['received_amount'], 2) . "</td>
                <td class='amount'>₹" . number_format($data['outstanding_amount'], 2) . "</td>
            </tr>";
        }
        
        $html .= "</table></div>";

        // Daily breakdown for range reports
        if ($report['report_type'] === 'range' && !empty($report['daily_breakdown'])) {
            $html .= "
                <div class='summary'>
                    <h3>Daily Breakdown</h3>
                    <table>
                        <tr><th>Date</th><th>Orders</th><th>Expected Amount</th><th>Received Amount</th><th>Outstanding Amount</th></tr>";
            
            foreach ($report['daily_breakdown'] as $day) {
                $html .= "<tr>
                    <td>{$day['date']}</td>
                    <td>{$day['orders_count']}</td>
                    <td class='amount'>₹" . number_format($day['expected_amount'], 2) . "</td>
                    <td class='amount'>₹" . number_format($day['received_amount'], 2) . "</td>
                    <td class='amount'>₹" . number_format($day['outstanding_amount'], 2) . "</td>
                </tr>";
            }
            
            $html .= "</table></div>";
        }

        // Detailed orders
        $html .= "
            <div class='orders'>
                <h3>Detailed Orders</h3>
                <table>
                    <tr>
                        <th>Challan No.</th>
                        <th>Order No.</th>
                        <th>Customer</th>
                        <th>Brick Type</th>
                        <th>Quantity</th>
                        <th>Total Amount</th>
                        <th>Payment Status</th>
                        <th>Received</th>
                        <th>Outstanding</th>
                        <th>Delivery Date</th>
                        <th>Sales Executive</th>
                    </tr>";

        foreach ($report['delivered_orders'] as $order) {
            $html .= "<tr>
                <td>{$order['challan_number']}</td>
                <td>{$order['order_number']}</td>
                <td>{$order['customer_name']}</td>
                <td>{$order['brick_type']}</td>
                <td>{$order['quantity']}</td>
                <td class='amount'>₹" . number_format($order['total_amount'], 2) . "</td>
                <td>" . ucfirst($order['payment_status']) . "</td>
                <td class='amount'>₹" . number_format($order['amount_received'], 2) . "</td>
                <td class='amount'>₹" . number_format($order['outstanding_amount'], 2) . "</td>
                <td>{$order['delivery_date']}</td>
                <td>{$order['sales_executive']}</td>
            </tr>";
        }

        $html .= "</table></div></body></html>";

        return $html;
    }

    /**
     * Generate CSV for Excel export
     */
    protected function generateReportCsv(array $report): string
    {
        $title = $report['report_type'] === 'daily' 
            ? "Daily Financial Report - {$report['date']}"
            : "Financial Report - {$report['from_date']} to {$report['to_date']}";

        $csv = "LGK Brick Management System\n";
        $csv .= "{$title}\n";
        $csv .= "Generated on: " . now()->format('Y-m-d H:i:s') . "\n\n";

        // Summary
        $csv .= "SUMMARY\n";
        $csv .= "Total Delivered Orders,{$report['summary']['total_delivered_orders']}\n";
        $csv .= "Total Expected Amount,{$report['summary']['total_expected_amount']}\n";
        $csv .= "Total Received Amount,{$report['summary']['total_received_amount']}\n";
        $csv .= "Total Outstanding Amount,{$report['summary']['total_outstanding_amount']}\n\n";

        // Payment status breakdown
        $csv .= "PAYMENT STATUS BREAKDOWN\n";
        $csv .= "Status,Count,Expected Amount,Received Amount,Outstanding Amount\n";
        foreach ($report['payment_status_breakdown'] as $status => $data) {
            $csv .= ucfirst($status) . ",{$data['count']},{$data['expected_amount']},{$data['received_amount']},{$data['outstanding_amount']}\n";
        }
        $csv .= "\n";

        // Daily breakdown for range reports
        if ($report['report_type'] === 'range' && !empty($report['daily_breakdown'])) {
            $csv .= "DAILY BREAKDOWN\n";
            $csv .= "Date,Orders,Expected Amount,Received Amount,Outstanding Amount\n";
            foreach ($report['daily_breakdown'] as $day) {
                $csv .= "{$day['date']},{$day['orders_count']},{$day['expected_amount']},{$day['received_amount']},{$day['outstanding_amount']}\n";
            }
            $csv .= "\n";
        }

        // Detailed orders
        $csv .= "DETAILED ORDERS\n";
        $csv .= "Challan No.,Order No.,Customer,Brick Type,Quantity,Total Amount,Payment Status,Received,Outstanding,Delivery Date,Sales Executive\n";
        foreach ($report['delivered_orders'] as $order) {
            $csv .= "\"{$order['challan_number']}\",\"{$order['order_number']}\",\"{$order['customer_name']}\",\"{$order['brick_type']}\",{$order['quantity']},{$order['total_amount']},\"{$order['payment_status']}\",{$order['amount_received']},{$order['outstanding_amount']},\"{$order['delivery_date']}\",\"{$order['sales_executive']}\"\n";
        }

        return $csv;
    }
}