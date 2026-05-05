<?php

namespace App\Filament\Teacher\Widgets;

use Filament\Widgets\Widget;

class ProgressNoticeWidget extends Widget
{
    protected static bool $isDiscovered = false;

    protected static string $view = 'filament.teacher.widgets.progress-notice';

    protected int|string|array $columnSpan = 'full';
}
