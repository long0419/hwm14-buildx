program hwm14_cli
    use hwm_interface, only : hwm_14      ! 注意调用的是 hwm_14
    implicit none

    real(8) :: glat, glon, alt_km
    integer :: doy
    real(8) :: utsec, ap
    real(8) :: w_merid, w_zonal
    integer :: narg
    character(len=64) :: arg

    ! 支持两种：5 参数(默认 ap=4)，或 6 参数（显式传 ap）
    narg = command_argument_count()
    if (narg < 5 .or. narg > 6) then
        print *, "Usage: hwm14_cli <lat> <lon> <alt_km> <doy> <ut_seconds> [ap]"
        stop 1
    end if

    call get_command_argument(1, arg); read(arg, *) glat
    call get_command_argument(2, arg); read(arg, *) glon
    call get_command_argument(3, arg); read(arg, *) alt_km
    call get_command_argument(4, arg); read(arg, *) doy
    call get_command_argument(5, arg); read(arg, *) utsec

    if (narg >= 6) then
        call get_command_argument(6, arg); read(arg, *) ap
    else
        ap = 4.0d0        ! 一个常用的安静期值
    end if

    ! 真正的模型调用
    call hwm_14(doy, utsec, alt_km, glat, glon, ap, w_merid, w_zonal)

    ! 输出
    write(*,'(A,2F14.6)') "Wmeridional Wzonal: ", w_merid, w_zonal

end program hwm14_cli
