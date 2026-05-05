<?php

namespace App\Filament\Widgets;

use App\Models\User;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class AdminStatsOverview extends BaseWidget
{
    protected static ?int $sort = -10;

    protected function getStats(): array
    {
        return [
            Stat::make('管理員帳號', (string) User::query()->where('role', User::ROLE_ADMIN)->count())
                ->description('可進入 /admin'),
            Stat::make('教師帳號', (string) User::query()->where('role', User::ROLE_TEACHER)->count())
                ->description('可進入 /teacher'),
            Stat::make('家長帳號', (string) User::query()->where('role', User::ROLE_PARENT)->count())
                ->description('可進入 /parent'),
            Stat::make('付費／訂閱', '—')
                ->description('尚未串接金流與訂閱資料表'),
        ];
    }
}
