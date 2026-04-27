<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;

/**
 * 各業務模組預留端點（尚未實作業務邏輯時回傳階段說明）。
 */
class ModuleStatusController extends Controller
{
    public function user(): JsonResponse
    {
        return $this->planned('user');
    }

    public function learning(): JsonResponse
    {
        return $this->planned('learning');
    }

    public function missions(): JsonResponse
    {
        return $this->planned('missions');
    }

    public function analytics(): JsonResponse
    {
        return $this->planned('analytics');
    }

    protected function planned(string $module): JsonResponse
    {
        return response()->json([
            'module' => $module,
            'phase' => 'planned',
            'message' => 'API Gateway 已分區；此模組業務邏輯尚未接上。',
        ]);
    }
}
