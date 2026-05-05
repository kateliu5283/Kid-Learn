<?php

namespace App\Filament\Resources\TeacherStudentResource\Pages;

use App\Filament\Resources\TeacherStudentResource;
use Filament\Actions;
use Filament\Resources\Pages\EditRecord;

class EditTeacherStudent extends EditRecord
{
    protected static string $resource = TeacherStudentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\DeleteAction::make(),
        ];
    }
}
