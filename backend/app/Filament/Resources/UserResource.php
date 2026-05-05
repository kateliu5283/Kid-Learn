<?php

namespace App\Filament\Resources;

use App\Filament\Resources\UserResource\Pages;
use App\Models\User;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Enums\FiltersLayout;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $navigationIcon = 'heroicon-o-users';

    protected static ?string $navigationGroup = '使用者與權限';

    protected static ?string $modelLabel = '帳號';

    protected static ?string $pluralModelLabel = '帳號';

    protected static ?int $navigationSort = 10;

    public static function form(Form $form): Form
    {
        return $form->schema([
            Forms\Components\Section::make('帳號內容')->schema([
                Forms\Components\TextInput::make('name')
                    ->label('姓名')
                    ->required()
                    ->maxLength(120),
                Forms\Components\TextInput::make('email')
                    ->label('Email')
                    ->email()
                    ->required()
                    ->unique(ignoreRecord: true)
                    ->maxLength(255),
                Forms\Components\Select::make('role')
                    ->label('角色')
                    ->options([
                        User::ROLE_ADMIN => '管理者',
                        User::ROLE_TEACHER => '教師',
                        User::ROLE_PARENT => '家長',
                    ])
                    ->required()
                    ->native(false),
                Forms\Components\TextInput::make('password')
                    ->label('密碼')
                    ->password()
                    ->revealable()
                    ->minLength(8)
                    ->dehydrated(fn (?string $state): bool => filled($state))
                    ->required(fn (string $context): bool => $context === 'create')
                    ->helperText(fn (string $context): string => $context === 'edit'
                        ? '留空表示不變更密碼'
                        : '至少 8 字元'),
                Forms\Components\TextInput::make('password_confirmation')
                    ->label('確認密碼')
                    ->password()
                    ->revealable()
                    ->same('password')
                    ->required(fn (string $context): bool => $context === 'create')
                    ->dehydrated(false)
                    ->visibleOn('create'),
            ]),
        ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('id')->label('ID')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('name')->label('姓名')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('email')->label('Email')->searchable()->sortable(),
                Tables\Columns\TextColumn::make('role')
                    ->label('角色')
                    ->badge()
                    ->formatStateUsing(fn (?string $state): string => match ($state) {
                        User::ROLE_ADMIN => '管理者',
                        User::ROLE_TEACHER => '教師',
                        User::ROLE_PARENT => '家長',
                        default => (string) $state,
                    })
                    ->color(fn (?string $state): string => match ($state) {
                        User::ROLE_ADMIN => 'danger',
                        User::ROLE_TEACHER => 'info',
                        User::ROLE_PARENT => 'success',
                        default => 'gray',
                    }),
                Tables\Columns\TextColumn::make('created_at')
                    ->label('建立時間')
                    ->dateTime('Y-m-d H:i')
                    ->sortable(),
            ])
            ->filters(
                [
                    Tables\Filters\Filter::make('keyword')
                        ->label('關鍵字')
                        ->form([
                            Forms\Components\TextInput::make('value')
                                ->label('姓名、Email 或 ID')
                                ->placeholder('輸入後按「套用篩選」'),
                        ])
                        ->query(function (Builder $query, array $data): Builder {
                            $v = isset($data['value']) ? trim((string) $data['value']) : '';
                            if ($v === '') {
                                return $query;
                            }

                            $escaped = addcslashes($v, '%_\\');
                            $like = '%'.$escaped.'%';

                            return $query->where(function (Builder $q) use ($like, $v): void {
                                $q->where('name', 'like', $like)
                                    ->orWhere('email', 'like', $like);
                                if (ctype_digit($v)) {
                                    $q->orWhere('id', (int) $v);
                                }
                            });
                        }),
                    Tables\Filters\Filter::make('created_between')
                        ->label('建立日期')
                        ->form([
                            Forms\Components\DatePicker::make('from')->label('起'),
                            Forms\Components\DatePicker::make('until')->label('迄'),
                        ])
                        ->query(function (Builder $query, array $data): Builder {
                            return $query
                                ->when(
                                    filled($data['from'] ?? null),
                                    fn (Builder $q) => $q->whereDate('created_at', '>=', $data['from'])
                                )
                                ->when(
                                    filled($data['until'] ?? null),
                                    fn (Builder $q) => $q->whereDate('created_at', '<=', $data['until'])
                                );
                        }),
                    Tables\Filters\SelectFilter::make('role')
                        ->label('角色')
                        ->options([
                            User::ROLE_ADMIN => '管理者',
                            User::ROLE_TEACHER => '教師',
                            User::ROLE_PARENT => '家長',
                        ])
                        ->multiple(),
                ],
                layout: FiltersLayout::AboveContent,
            )
            ->filtersFormColumns(2)
            ->persistFiltersInSession()
            ->persistSearchInSession()
            ->searchPlaceholder('搜尋姓名、Email、ID…')
            ->defaultSort('id', 'desc')
            ->paginationPageOptions([10, 25, 50, 100])
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make()
                        ->action(function ($records): void {
                            $records->each(function (User $record): void {
                                if ($record->id !== auth()->id()) {
                                    $record->delete();
                                }
                            });
                        }),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListUsers::route('/'),
            'create' => Pages\CreateUser::route('/create'),
            'edit' => Pages\EditUser::route('/{record}/edit'),
        ];
    }
}
