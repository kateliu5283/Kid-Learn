<?php

namespace App\Filament\Resources;

use App\Filament\Resources\StudentResource\Pages;
use App\Models\Student;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Enums\FiltersLayout;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class StudentResource extends Resource
{
    protected static ?string $model = Student::class;

    protected static ?string $navigationIcon = 'heroicon-o-academic-cap';

    protected static ?string $navigationGroup = '使用者與權限';

    protected static ?string $modelLabel = '學生';

    protected static ?string $pluralModelLabel = '學生（雲端）';

    protected static ?int $navigationSort = 11;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make()->schema([
                Forms\Components\Select::make('parent_user_id')
                    ->label('家長帳號')
                    ->relationship(
                        'parent',
                        'email',
                        fn (Builder $query) => $query->where('role', User::ROLE_PARENT)->orderBy('email')
                    )
                    ->searchable()
                    ->preload()
                    ->required(),
                Forms\Components\TextInput::make('name')
                    ->label('孩子顯示名稱')
                    ->required()
                    ->maxLength(120),
                Forms\Components\Select::make('grade')
                    ->label('年級')
                    ->options([
                        1 => '1 年級', 2 => '2 年級', 3 => '3 年級', 4 => '4 年級', 5 => '5 年級', 6 => '6 年級',
                    ])
                    ->required()
                    ->native(false),
                Forms\Components\TextInput::make('avatar')
                    ->label('頭像（emoji 或代碼）')
                    ->maxLength(32),
                Forms\Components\TextInput::make('device_local_id')
                    ->label('App 本機 profile id')
                    ->maxLength(64)
                    ->helperText('與 Flutter 本機孩子 id 對應，可留空'),
                Forms\Components\TextInput::make('sort')
                    ->label('排序')
                    ->numeric()
                    ->default(0)
                    ->required(),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')->label('ID')->sortable(),
                Tables\Columns\TextColumn::make('parent.email')
                    ->label('家長 Email')
                    ->searchable()
                    ->sortable(),
                Tables\Columns\TextColumn::make('name')->label('姓名')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('grade')
                    ->label('年級')
                    ->formatStateUsing(fn ($state): string => "{$state} 年級")
                    ->sortable(),
                Tables\Columns\TextColumn::make('device_local_id')->label('本機 ID')->placeholder('—')->toggleable(),
                Tables\Columns\TextColumn::make('created_at')->label('建立')->dateTime('Y-m-d H:i')->sortable(),
            ])
            ->filters(
                [
                    Tables\Filters\SelectFilter::make('parent_user_id')
                        ->label('家長')
                        ->relationship(
                            'parent',
                            'email',
                            fn (Builder $query) => $query->where('role', User::ROLE_PARENT)->orderBy('email')
                        )
                        ->searchable()
                        ->preload(),
                    Tables\Filters\SelectFilter::make('grade')
                        ->label('年級')
                        ->options([1 => '1', 2 => '2', 3 => '3', 4 => '4', 5 => '5', 6 => '6']),
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
            'index' => Pages\ListStudents::route('/'),
            'create' => Pages\CreateStudent::route('/create'),
            'edit' => Pages\EditStudent::route('/{record}/edit'),
        ];
    }
}
