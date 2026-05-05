<?php

namespace App\Filament\Resources\TeacherStudentResource\Pages;

use App\Filament\Resources\TeacherStudentResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListTeacherStudents extends ListRecords
{
    protected static string $resource = TeacherStudentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
