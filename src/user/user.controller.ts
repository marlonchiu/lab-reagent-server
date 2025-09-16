import {
  Controller,
  Get,
  Query,
  Param,
  Patch,
  Body,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { UserDto } from './dto/user.dto';

@Controller('user')
export class UserController {
  @Get()
  findAll(
    @Query('keyword') keyword: string,
    @Query('page') page: number,
    @Query('pageSize') pageSize: number,
  ) {
    console.log(keyword, page, pageSize);
    return 'This action returns all user';
  }

  // get 中的 id 要和 @Param('id')  一致
  @Get(':id')
  findOne(@Param('id') uid: string) {
    console.log(uid);
    return {
      id: uid,
      title: 'title',
      desc: 'content',
    };
  }

  // 修改
  @Patch(':id')
  updateOne(@Param('id') uid: string, @Body() userDto: UserDto) {
    console.log(uid);
    console.log(userDto);
    return {
      id: uid,
    };
  }

  // 测试错误
  @Get('error')
  getTest(): string {
    throw new HttpException('获取数据失败', HttpStatus.BAD_REQUEST);
  }
}
