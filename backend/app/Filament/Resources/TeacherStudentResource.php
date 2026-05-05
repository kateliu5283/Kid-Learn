<?php

namespace App\Filament\Resources;

use App\Filament\Resources\TeacherStudentResource\Pages;
use App\Models\Student;
use App\Models\TeacherStudent;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Enums\FiltersLayout;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

/**
 * 家教／小班：一位教師可帶多位學生（多對多）。
 */
class TeacherStudentResource extends Resource
{
    protected static ?string $model = TeacherStudent::class;

    protected static ?string $navigationIcon = 'heroicon-o-link';

    protected static ?string $navigationGroup = '使用者與權限';

    protected static ?string $modelLabel = '教師—學生';

    protected static ?string $pluralModelLabel = '教師帶領（家教／小班）';

    protected static ?int $navigationSort = 12;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make()->schema([
                Forms\Components\Select::make('teacher_user_id')
                    ->label('教師')
                    ->relationship(
                        'teacher',
                        'email',
                        fn (Builder $query) => $query->where('role', User::ROLE_TEACHER)->orderBy('name')
                    )
                    ->getOptionLabelFromRecordUsing(fn (User $u): string => "{$u->name}（{$u->email}）")
                    ->searchable(['name', 'email'])
                    ->preload()
                    ->required(),
                Forms\Components\Select::make('student_id')
                    ->label('學生')
                    ->relationship(
                        'student',
                        'name',
                        fn (Builder $query) => $query->with('parent')->orderByDesc('id')
                    )
                    ->getOptionLabelFromRecordUsing(
                        fn (Student $s): string => "{$s->name}（家長：{$s->parent?->email}）"
                    )
                    ->searchable(['name'])
                    ->preload()
                    ->required(),
                Forms\Components\TextInput::make('note')
                    ->label('備註')
                    ->maxLength(255)
                    ->placeholder('例：數學家教、週三小班…'),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')->label('ID')->sortable(),
                Tables\Columns\TextColumn::make('teacher.name')->label('教師')->searchable(),
                Tables\Columns\TextColumn::make('teacher.email')->label('教師 Email')->toggleable(),
                Tables\Columns\TextColumn::make('student.name')->label('學生')->searchable(),
                Tables\Columns\TextColumn::make('student.parent.email')->label('家長 Email')->toggleable(),
                Tables\Columns\TextColumn::make('note')->label('備註')->limit(30)->placeholder('—'),
                Tables\Columns\TextColumn::make('created_at')->label('建立')->dateTime('Y-m-d H:i')->sortable(),
            ])
            ->filters(
                [
                    Tables\Filters\SelectFilter::make('teacher_user_id')
                        ->label('教師')
                        ->relationship(
                            'teacher',
                            'email',
                            fn (Builder $query) => $query->where('role', User::ROLE_TEACHER)->orderBy('email')
                        )
                        ->searchable()
                        ->preload(),
                ],
                layout: FiltersLayout::AboveContent,
            )
            ->filtersFormColumns(2)
            ->persistFiltersInSession()
            ->persistSearchInSession()
            ->defaultSort('id', 'desc')
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListTeacherStudents::route('/'),
            'create' => Pages\CreateTeacherStudent::route('/create'),
            'edit' => Pages\EditTeacherStudent::route('/{record}/edit'),
        ];
    }
}
