<?php

namespace App\Filament\ParentPortal\Widgets;

use App\Models\User;
use Filament\Widgets\Widget;

class ProgressNoticeWidget extends Widget
{
    protected static bool $isDiscovered = false;

    protected static string $view = 'filament.parent-portal.widgets.progress-notice';

    protected int|string|array $columnSpan = 'full';

    /**
     * @return array<string, mixed>
     */
    protected function getViewData(): array
    {
        $user = auth()->user();
        if (! $user instanceof User || $user->role !== User::ROLE_PARENT) {
            return ['students' => collect()];
        }

        return [
            'students' => $user->students()->orderBy('sort')->get(),
        ];
    }
}
