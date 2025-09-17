import {
  Controller,
  Get,
  Query,
  Param,
  Patch,
  Body,
  Post,
  Delete,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { UserService } from './user.service';
import { UserDto } from './dto/user.dto';

@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) {}

  // 分页查询
  @Get('/page')
  findAll(
    @Query('keyword') keyword: string,
    @Query('page') page: number,
    @Query('pageSize') pageSize: number,
  ) {
    console.log(keyword, page, pageSize);
    return this.userService.findAll();
  }

  // 创建
  @Post('/create')
  create(@Body() userDto: UserDto) {
    return this.userService.create(userDto);
  }

  // get 中的 id 要和 @Param('id')  一致
  // 查询 根据 id 查询
  @Get(':id')
  findOne(@Param('id') id: string) {
    console.log(id);
    return this.userService.findOne(id);
  }

  // 修改
  @Patch(':id')
  async updateOne(@Param('id') id: string, @Body() userDto: UserDto) {
    console.log(id, userDto);
    // return this.userService.updateOne(id, userDto);
    // 数据库返回
    // { "acknowledged": true, "modifiedCount": 1, "upsertedId": null, "upsertedCount": 0, "matchedCount": 1 }
    const data = await this.userService.updateOne(id, userDto);
    console.log('🚀 ~ UserController ~ updateOne ~ data:', data);
    // 修改成功 返回当前数据的id
    if (data.modifiedCount === 1) {
      return id;
    } else {
      throw new HttpException('更新失败', HttpStatus.BAD_REQUEST);
    }
  }

  @Delete(':id')
  deleteOne(@Param('id') id: string) {
    return this.userService.deleteOne(id);
  }

  // 测试错误
  // @Get('error')
  // getTest(): string {
  //   throw new HttpException('获取数据失败', HttpStatus.BAD_REQUEST);
  // }
}
