<?php

namespace App\Filament\ParentPortal\Resources\ParentStudentResource\Pages;

use App\Filament\ParentPortal\Resources\ParentStudentResource;
use App\Models\Student;
use Filament\Resources\Pages\CreateRecord;

class CreateParentStudent extends CreateRecord
{
    protected static string $resource = ParentStudentResource::class;

    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $data['parent_user_id'] = auth()->id();
        $max = (int) Student::query()
            ->where('parent_user_id', auth()->id())
            ->max('sort');
        $data['sort'] = $max + 1;

        return $data;
    }
}
