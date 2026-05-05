<?php

namespace App\Filament\ParentPortal\Resources\ParentStudentResource\Pages;

use App\Filament\ParentPortal\Resources\ParentStudentResource;
use Filament\Actions;
use Filament\Resources\Pages\ListRecords;

class ListParentStudents extends ListRecords
{
    protected static string $resource = ParentStudentResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }
}
